From: Harsh Jain <Harsh@chelsio.com>
Subject: Re: [PATCH 3/7] crypto:gf128mul: The x8_ble multiplication functions
Date: Thu, 5 Oct 2017 16:50:14 +0530
Message-ID: <d4d07658-9f21-4935-6d38-eccf038ca209@chelsio.com>
References: <cover.1507010612.git.harsh@chelsio.com>
 <3e443f7a245229a2752fcf21dfed10998847e345.1507010612.git.harsh@chelsio.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0088A2B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0088A2B@AcuExch.aculab.com>
Content-Language: en-US
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03-10-2017 20:28, David Laight wrote:
> From: Harsh Jain
>> Sent: 03 October 2017 07:46
>> It multiply GF(2^128) elements in the ble format.
>> It will be used by chelsio driver to fasten gf multiplication.
>                                        ^ speed up ??
It should be speed up. Will fix the same in V2. Thanks
>
> 	David
>
