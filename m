From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Fri, 30 Mar 2012 11:31:54 -0700
Message-ID: <CAB=NE6U+-jj9yiz3_xb7jPUWJH5KQhxgJ5=m9Whny-DTr46WNg@mail.gmail.com>
References: <1330480210-30470-1-git-send-email-rodrigue@qca.qualcomm.com> <CAA93jw4NwHaLazxK2Eo6a6TuvF3svqdZjTpHUwOyEHv-Q=busQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qca-linux-team@qualcomm.com,
	nic-devel@qualcomm.com, kgiori@qca.qualcomm.com,
	chris.snook@gmail.com, mathieu@qca.qualcomm.com, bryanh@quicinc.com
To: Dave Taht <dave.taht@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAA93jw4NwHaLazxK2Eo6a6TuvF3svqdZjTpHUwOyEHv-Q=busQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 30, 2012 at 11:16 AM, Dave Taht <dave.taht@gmail.com> wrote:
>
>
> On Wed, Feb 29, 2012 at 1:50 AM, Luis R. Rodriguez
> <rodrigue@qca.qualcomm.com> wrote:
>>
>> From: Luis R. Rodriguez <mcgrof@frijolero.org>
>>
>> The next patch adds the new QCA alx Ethernet driver that
>> supercedes the atl1c Ethernet driver. For details please
>> read the commit log of the patch. Given the size you can
>> download the patch from:
>
>
>
>>
>>
>>
>> http://bombadil.infradead.org/~mcgrof/2012/02/28/add-alx-next-20120228.patch
>> sha1sum: 8a8f7b6f1cbe737e70ec3b3eda483a6925fd9bd6
>>
>
> The shiny graph was rather impressive vs a vs the old driver.
>
> https://www.linuxfoundation.org/sites/main/files/alx-iperf.jpg
>
> A quick grep showed no BQL support. :(

Good point, we'll add that to our TODO list.

  Luis
