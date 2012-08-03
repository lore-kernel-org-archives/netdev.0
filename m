From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: Re: [REGRESSION][v3.5] iwlwifi: include rssi as part of decision
 making for reduce txpower
Date: Fri, 03 Aug 2012 12:43:24 -0400
Message-ID: <501BFFAC.2010705@canonical.com>
References: <501BFB29.7010801@canonical.com>  (sfid-20120803_182456_195468_6BBC5170) <1344011416.4482.11.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wey-yi.w.guy@intel.com, ilw@linux.intel.com,
	linville@tuxdriver.com, emmanuel.grumbach@intel.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344011416.4482.11.camel@jlt3.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2012 12:30 PM, Johannes Berg wrote:
> On Fri, 2012-08-03 at 12:24 -0400, Joseph Salisbury wrote:
>
>> A test kernel was created with this commit reverted, which stopped the
>> kernel panic from occurring.
>>
>> A bugzilla bug[1] has been opened.
>> [0] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1029547
>> [1] https://bugzilla.kernel.org/show_bug.cgi?id=45491
> This is a duplicate of https://bugzilla.kernel.org/show_bug.cgi?id=45481
> which I've already commented on with the correct fix. I've also sent the
> fix to stable:
>
> http://www.mail-archive.com/stable@vger.kernel.org/msg12286.html
>
> Thanks,
> johannes
>
Great!  Thanks for the feedback, Johannes.
