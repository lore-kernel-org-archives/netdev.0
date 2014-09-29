From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] staging: r8821ae: Remove driver from staging
Date: Mon, 29 Sep 2014 09:45:33 -0500
Message-ID: <5429708D.4080402@lwfinger.net>
References: <1411954791-23779-1-git-send-email-Larry.Finger@lwfinger.net>
 <20140929061744.GA25093@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140929061744.GA25093@kroah.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 09/29/2014 01:17 AM, Greg KH wrote:
> On Sun, Sep 28, 2014 at 08:39:51PM -0500, Larry Finger wrote:
>> A new version of this driver has been merged into the wireless-testing tree
>> as commit 21e4b0726dc671c423e2dc9a85364716219c4502. It is both possible and
>> desirable to delete the staging version to avoid build errors in linux-next.
>>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> ---
>>
>> Greg,
>>
>> This removal patch was generated after commit 368c75b98bdfdfad54e7f165016819ef344e3587.
>> It should apply to your tree unless further modifications have been made to
>> the staging driver.
>
> Wonderful!
>
> So, this should be done for 3.18-rc1, right?  Or does wireless-testing
> take longer to get to Linus than that?

Yes, it should be for 3.18-rc1. Sorry that I did not make that more clear.

It is also likely that I will be sending a similar delete patch for r8192ee. 
John has the patch to add a new version to wireless-testing, but has not yet 
merged it.

Larry
