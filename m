From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] staging: r8188eu: Fix typo in USB_DEVICE list
Date: Sun, 02 Feb 2014 15:22:04 -0600
Message-ID: <52EEB6FC.8070603@lwfinger.net>
References: <1391371626-13551-1-git-send-email-Larry.Finger@lwfinger.net>
 <52EEB2E3.8090306@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Randy Dunlap <rdunlap@infradead.org>, gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <52EEB2E3.8090306@infradead.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On 02/02/2014 03:04 PM, Randy Dunlap wrote:
> On 02/02/2014 12:07 PM, Larry Finger wrote:
>> There is a typo in the device list that interchanges the vendor and
>> product codes for one of the entries.
>
> You also changed 0x7b8 to 0x7bb.
> Did you mean to do that?

No, I did not. Thanks for catching that typo.

Larry
