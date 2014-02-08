From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] staging: r8188eu: Fix missing header
Date: Fri, 07 Feb 2014 18:09:47 -0600
Message-ID: <52F575CB.8060607@lwfinger.net>
References: <1391814730-3461-1-git-send-email-Larry.Finger@lwfinger.net>
 <20140208000423.GB17796@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140208000423.GB17796@kroah.com>
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

On 02/07/2014 06:04 PM, Greg KH wrote:
> On Fri, Feb 07, 2014 at 05:12:10PM -0600, Larry Finger wrote:
>> Commit 2397c6e0927675d983b34a03401affdb64818d07 entitled "staging: r8188eu:
>> Remove wrappers around vmalloc and vzalloc" and
>> commit: 03bd6aea7ba610a1a19f840c373624b8b0adde0d entitled "staging: r8188eu:
>> Remove wrappers around vfree" failed to add the header file needed
>> to provide vzalloc and vfree.
>>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>
> Was this reported by the 0-day bot?  If so, please credit it.

Yes it was. V2 coming soon.

Larry
