$(document).ready(function () {

  $(".nav-auctions").click(function() {
    $([document.documentElement, document.body]).animate({
        scrollTop: $(".auctions").offset().top
    }, 500);
});
$(".nav-marketplace").click(function() {
  $([document.documentElement, document.body]).animate({
      scrollTop: $(".activelots-block").offset().top
  }, 500);
});
  console.log("Jquery loaded");
  fetch("./contractAbi.json")
    .then((response) => response.json()) 
    .then((abiFile) => {
      const contractAddress = "0x2c26706d815307E0Cd2769254F2d730e0f5A3D32";
      const provider = new Web3.providers.HttpProvider("http://127.0.0.1:8545"); // Замените на свой провайдер
      const web3 = new Web3(provider);
      const contract = new web3.eth.Contract(abiFile, contractAddress);
      var $balanceTokens = $("#balance span");
      var $nftIdInput = $("#nftIdInput");
      var $nftList = $(".NftList");
      var allLotsLength = 0;
      var $buyNftBlock = $('.buyNft-block')
      var $auctionsBlock = $('.auctions')
      var $sellNftBtn = $('.sellNft__button');
      var $sellNftBlock = $(".sellNft-block")
      var $nftSingleBlock = $("#nftSingleBlock");
      var $userAllSingleNft = $(".userAllSingleNft");
      var $createNftBlock = $(".create-nft-block");
      var $showLotsBtn = $('.showLots')
      var $activeLotsList = $('.activeLots__list')
      var $activelotsBlock = $('.activelots-block');
      var $createNftCollectionBlock = $(".create-nftCollection-block");
      var $tokenManipulations = $(".tokenManipulations");
      var $nftCollectionIdInput = $("#nftCollectionIdInput");
      var $viewNFTColectionBtn = $("#viewNFTColectionBtn");
      var $collectionIdView = $(".collection-id");
      var $refCodeActivateBlock = $(".refCode-block");
      var $activateRefCodeInput = $("#activateRefCodeInput");
      var $activateRefCodeBtn = $("#activateRefCodeBtn");
      
      // Обработка выбора пользователя
      $user.change(function () {
        
        var $nftList = $(".NftList");
        let selectedUser = $user.val();
        if (selectedUser !== "none") {
          
          $refCodeText.show();
          $sellNftBlock.show();
          $auctionsBlock.show();
          $activelotsBlock.show();
          $createNftBlock.show();
          $buyNftBlock.show();
          $refCodeActivateBlock.show();
          $createNftCollectionBlock.show();
          $createRefCode.show();
          $userAllSingleNft.show();
          $nftSingleBlock.show();
          $tokenManipulations.show();
          $refCodeBonus.show();
          showUserNftId ();
          $collectionIdView.empty();
          $viewNFTColectionBtn.click(function () {
            var idnftcoll = $nftCollectionIdInput.val();
            var selectedUser = $user.val();
            $collectionIdView.empty();
            contract.methods
              .showNftCollection(idnftcoll)
              .call({ from: selectedUser })
              .then(function (array) {
                $collectionIdView.text(
                  `Айди нфт внутри коллекции: ${array.join(", ")}`
                );
              })
              .catch(function (error) {
                console.error(error);
              });
          });
          $activateRefCodeBtn.click(function () {
            selectedUser = $user.val();
            var refka = $activateRefCodeInput.val();
            contract.methods
              .activateRefcode(refka)
              .send({ from: selectedUser })
              .then(function () {
                showBalance();
                $activateRefCodeInput.val("");
              })
              .catch(function (error) {
                console.error(error);
                $activateRefCodeInput.val("");
              });
          });
          showBalance();
          function showBalance () {
            contract.methods
            .balanceOf(selectedUser)
            .call({ from: selectedUser })
            .then(function (balance) {
              $balanceTokens.text(balance.toString().slice(0, -6));
            })
            .catch(function (error) {
              console.log("here 0");
              console.error(error);
            });
          }


          $sellNftBtn.click(function () {
            var sellNftId = $('#sellnftId').val();
            var sellCollectionId = $('#sellcollectionId').val();
            var sellNftQuantity = $('#sellNftquantity').val(); 
            var sellNftPrice = $('#sellNftprice').val();  
            if (sellNftPrice != null, sellNftQuantity != null,sellCollectionId != null,sellNftId != null){
              contract.methods.sellNfs(sellNftId,sellNftQuantity,sellNftPrice,sellCollectionId).send({from: selectedUser}).then(function () {
                reloadAllLotsLength();
                showUserNftId ();
                alert('Nft sell created');
              }).catch(function (error) {
                console.error(error);
              })
            }
          })





          $("#viewNFTBtn").click(function () {
            var nftId = $nftIdInput.val();
            var selectedUser = $user.val();
            $nftList.empty(); // Очистка содержимого элемента $nftList
            contract.methods
              .getNftImg(nftId)
              .call({ from: selectedUser })
              .then(function (path) {
                if (path !== "") {
                  const imgElement = document.createElement("img");
                  imgElement.src = path;
                  imgElement.classList.add("nft-image");
                  $nftList.empty().append(imgElement);
                } else {
                  alert("Это не ваша NFT.");
                }
              })
              .catch(function (error) {
                console.error(error);
              });
          });
          $(".selected-user").text(`Выбранный пользователь: ${selectedUser}`);
          $balance.show();
          $interface.show();
          function showUserNftId () {
            contract.methods
                  .nftIdsSender()
                  .call({ from: selectedUser })
                  .then(function (nftArray) {
                    $userAllSingleNft.text(`Айди ваших NFT ${nftArray}`);
                  })
                  .catch(function (error) {
                    console.error(error);
                  });
          }
          showUserNftId ()
          $("#createNFTForm").submit(function (event) {
            event.preventDefault();
            selectedUser = $user.val();
            var nftFormName = $("#name").val();
            var nftFormDescription = $("#description").val();
            var nftFormPrice = $("#price").val();
            var nftFormQuantity = $("#quantity").val();
            var nftFormImage = $("#image").val();
            showUserNftId ()
            contract.methods
              .createNFT(
                nftFormName,
                nftFormDescription,
                nftFormImage,
                nftFormPrice,
                nftFormQuantity
              )
              .send({ from: selectedUser })
              .then(function () {
                // Очистка полей после успешного создания NFT
                $("#name").val("");
                $("#description").val("");
                $("#price").val("");
                $("#quantity").val("");
                $("#image").val("");
                selectedUser = $user.val();
                // Получение только одного NFT после создания
                showUserNftId ()
              })
              .catch(function (error) {
                console.error(error);
              });
          });

          $("#createnftCollectionForm").submit(function (event) {
            event.preventDefault();
            selectedUser = $user.val();
            var nftCollectionFormName = $("#collectionName").val();
            var nftCollectionFormDescription = $(
              "#collectionDescription"
            ).val();

            var nftCollectionidArray = $("#idArray").val();
            var nftCollectionvalueArray = $("#valueArray").val();

            // Преобразование строк в массивы
            var arrayId = nftCollectionidArray.split(",");
            var arrayValue = nftCollectionvalueArray.split(",");

            // Добавьте проверку на соответствие id и value
            if (arrayId.length !== arrayValue.length) {
              console.error("Длина массивов id и value должна быть одинаковой");
              return;
            }
            contract.methods
            .nftCollectionsSendId()
            .call({ from: selectedUser })
            .then(function (nftCollectionArray) {
              $(".userAllCollection").text(
                `Айди ваших коллекции NFT: ${nftCollectionArray}`
              );
            })
            .catch(function (error) {
              console.error(error);
            });
            contract.methods
              .createCollections(
                nftCollectionFormName,
                nftCollectionFormDescription,
                arrayId,
                arrayValue
              )
              .send({ from: selectedUser })
              .then(function () {
                // Очистка полей после успешного создания коллекции
                $("#collectionName").val("");
                $("#collectionDescription").val("");
                $("#valueArray").val("");
                $("#idArray").val("");
                contract.methods
                  .nftCollectionsSendId()
                  .call({ from: selectedUser })
                  .then(function (nftCollectionArray) {
                    $(".userAllCollection").text(
                      `Айди ваших коллекции NFT: ${nftCollectionArray}`
                    );
                  })
                  .catch(function (error) {
                    console.error(error);
                  });
              })
              .catch(function (error) {
                console.error(error);
              });
          });

          contract.methods
            .nftCollectionsSendId()
            .call({ from: selectedUser })
            .then(function (nftCollectionArray) {
              $(".userAllCollection").text(
                `Айди ваших коллекции NFT: ${nftCollectionArray}`
              );
            })
            .catch(function (error) {
              console.error(error);
            });
            
            function reloadAllLotsLength() {
              selectedUser = $user.val();
              contract.methods.getSellNFTsCount().call({ from: selectedUser }).then(function (arrayLength) {
                  allLotsLength = arrayLength;
                  $activeLotsList.empty(); // Очистка содержимого элемента $activeLotsList
                  $activeLotsList.text('Все лоты'); // Добавляем текст "Все лоты:" перед списком лотов
                  for (let i = 0; i < arrayLength; i++) {
                      $activeLotsList.append(`, ${i}`); // Добавляем текст к существующему содержимому
                  }
              });
          }
            reloadAllLotsLength()
            
            function showLot() {
              selectedUser = $user.val();
              reloadAllLotsLength()
              if ($('#lotId').val() != '') {
                contract.methods.getAllNFTsForSale($('#lotId').val()).call({from: selectedUser}).then(function (lot) {
                  let $lotPrice = $('.lot__Price');
                  let $lotColId = $('.lot__collId');
                  let $lotValue = $('.lot__Value');
                  let $lotIsActive = $('.lot__isActive'); 
                  let $lotNftId = $('.lot__nftId');
                  $lotNftId.text(`Айди нфт: ${lot[0]}`);
                  $lotIsActive.text(`Активен: ${lot[4]}`);
                  $lotValue.text(`Количество: ${lot[2]}`);
                  $lotPrice.text(`Цена: ${lot[3]}`);
                  $lotColId.text(`Айди коллекции(0 нету коллекции): ${lot[1]}`);
                })
              }
            }
            showLot();
            $showLotsBtn.click(function () {
              showLot();
            })

          $("#sellTokensBtn").click(async function () {
            var value = $quantityTokens.val();
            if (selectedUser !== "none") {
              // Запрос разрешения на подключение к аккаунту MetaMask
              ethereum
                .request({ method: "eth_requestAccounts" })
                .then(function (accounts) {
                  // Оценка газового предела
                  contract.methods
                    .sellToken(value)
                    .send({ from: selectedUser })
                    .catch(function (error) {
                      console.error("Ошибка при выполнении транзакции:", error);
                    })
                    .then(function (receipt) {
                      console.log(
                        "Транзакция успешно выполнена:",
                        receipt.transactionHash
                      );
                      $quantityTokens.val("");
                      // Обновление баланса токенов
                      showBalance();
                    })
                    .catch(function (error) {
                      console.log("here 1");
                      console.error(error);
                    });
                })
                .catch(function (error) {
                  console.log("here 2");
                  console.error(error);
                });
            }
          });

          $("#buyTokensBtn").click(async function () {
            var value = $quantityTokens.val();
            if (selectedUser !== "none") {
              // Запрос разрешения на подключение к аккаунту MetaMask
              ethereum
                .request({ method: "eth_requestAccounts" })
                .then(function (accounts) {
                  const from = "0x4FA0aC33F471268cA19f241aED4f25D9CF4D161B";
                  // Оценка газового предела
                  contract.methods
                    .buyToken(value)
                    .send({
                      from: selectedUser,
                      value: web3.utils.toWei(value.toString(), "ether"),
                    })
                    .catch(function (error) {
                      console.error("Ошибка при выполнении транзакции:", error);
                    })
                    .then(function (receipt) {
                      console.log(
                        "Транзакция успешно выполнена:",
                        receipt.transactionHash
                      );
                      $quantityTokens.val("");
                      // Обновление баланса токенов
                      showBalance();
                    })

                    .catch(function (error) {
                      console.log("here 1");
                      console.error(error);
                    });
                })
                .catch(function (error) {
                  console.log("here 2");
                  console.error(error);
                });
            }
          });

          $createRefCode.click(function () {
            selectedUser = $user.val();
            var referralCode = selectedUser.slice(2, 6);
            var formattedReferralCode = "PROFI-"+referralCode+"2023";
            contract.methods
              .createCode(formattedReferralCode)
              .send({ from: selectedUser })
              .then(function () {
                $refCodeText.text(
                  `Ваш реферальный код: ${formattedReferralCode}`
                );
              })
              .catch(function (error) {
                console.error(error);
              });
          });

          $('#buyLotBtn').click(function() {
            selectedUser = $user.val();
            var lotId = $('#lotId').val();
            contract.methods.byNft(lotId).call({ from:selectedUser}).then(function () {
                showBalance();
                showUserNftId();
            }).catch(function (error) {
                console.error(error);
            });
        });

          contract.methods
            .check(selectedUser)
            .call()
            .then(function (refka) {
              $refCodeText.text(`Ваш реферальный код: ${refka}`);
            })
            .catch(function (error) {
              console.error(error);
            });

          // Получение баланса токенов для выбранного пользователя
          showBalance();
        } else {
          $refCodeText.hide();
          $sellNftBlock.hide();
          $auctionsBlock.hide();
          $createNftCollectionBlock.hide();
          $activelotsBlock.hide()
          $buyNftBlock.hide();
          $createRefCode.hide();
          $refCodeBonus.hide();
          $createNftBlock.hide();
          $refCodeActivateBlock.hide();
          $userAllSingleNft.hide();
          $nftList.empty(); // Очистка содержимого элемента $nftList
          $nftSingleBlock.hide();
          $tokenManipulations.hide();
          $balance.hide();
          $(".selected-user").text(`Выбранный пользователь:`);
          $interface.hide();

          // Очистка полей формы
          $("#name").val("");
          $("#description").val("");
          $("#price").val("");
          $("#quantity").val("");
          $("#image").val("");
        }
      });
      // Вызов события изменения select для инициализации интерфейса
      $user.trigger("change");
    })
    .catch(function (error) {
      console.error(error);
    });

  // Показ баланса и форм для владельца
  var $nftCreate = $("#nft-create");
  var $nftDivForm = $("#nft-div-form");
  var $balance = $("#balance");
  var $createRefCode = $("#createRefCode");
  var $refCodeText = $(".userRefCode");
  var $tokenMethods = $("#tokens-methods");
  var $interface = $("#interface");
  var $buyTokensBtn = $("#buyTokensBtn");
  var $nftIdInput = $("#nftIdInput");
  var $sellTokensBtn = $("#sellTokensBtn");
  var $quantityTokens = $("#quantity-tokens");
  var $nftForm = $("#nftForm");
  var $refCodeBonus = $(".refCodeBonus");
  var $referalQuantity = $(".referal-quantity");
  var $nftList = $(".NftList");
  var $refCodeIsActive = $(".refCodeIsActive");
  var $user = $("#user");
  $nftCreate.hide();
  $balance.hide();
  $interface.hide();
  $nftForm.hide();

  $referalQuantity.hide();

  // Проверка наличия MetaMask
  if (typeof window.ethereum === "undefined") {
    alert("Пожалуйста установите MetaMask.");
    return;
  }

  // Получение аккаунтов MetaMask
  window.ethereum
    .request({ method: "eth_requestAccounts" })
    .then(function (accounts) {
      // Добавление аккаунтов в select
      for (var i = 0; i < accounts.length; i++) {
        $user.append(
          $("<option>", {
            value: accounts[i],
            text: accounts[i],
          })
        );
      }
      // Обработка выбора пользователя
      $user.change(function () {
        var selectedUser = $user.val();
        if (selectedUser !== "none") {
          $balance.show();
          $nftList.empty();
          $interface.show();
        } else {
          $balance.hide();
          $nftList.empty();
          $interface.hide();
        }
      });
      // Вызов события изменения select для инициализации интерфейса
      $user.trigger("change");
    })
    .catch(function (error) {
      console.error(error);
    });

  // Остальной код вашего интерфейса
  $("#sell-token, #buy-token").click(function (event) {
    event.preventDefault();
  });

  $("#showFormBtn").click(function (event) {
    event.preventDefault();
    $nftForm.show();
  });


  $("#clearFormBtn").click(function () {
    $nftForm.hide();
  });
});
