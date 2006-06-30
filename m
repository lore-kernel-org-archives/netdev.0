From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6 (revised)
Date: Fri, 30 Jun 2006 12:31:00 -0400
Message-ID: <44A551C4.8090208@garzik.org>
References: <20060626212547.GE30706@tuxdriver.com> <20060628004838.GA15906@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:14779 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932630AbWF3QbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 12:31:04 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060628004838.GA15906@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Mon, Jun 26, 2006 at 05:25:52PM -0400, John W. Linville wrote:
> 
>> Michael Buesch:
>>       bcm43xx: suspend MAC while executing long pwork
> 
> The above patch ruffled some feathers on netdev.  In the interest of
> moving things along, I have pulled that patch out of wireless-2.6.
> I expect it will be back soon, probably with some additional changes
> to satisfy concerns raised on the mailing list.
> 
> NOTE: While I was mucking around, I pulled a bunch of patches from
> the master branch out into driver-specific branches for adm8211,
> prism54usb, tiacx, and zd1211rw.  Then I rebuilt the master branch
> by pulling from the driver branches.  This is intended to ease the
> merging of individual drivers upstream (e.g. zd1211rw and maybe tiacx
> in the near future).
> 
> Those working off my upstream branch or off Linus' tree should be
> unaffected.  Anyone who works off my master branch may need to rebase,
> especially if they want me to be able to pull from them (due to dirty
> history).  I apologize for the hassle and appreciate your cooperation!
> 
> Thanks,
> 
> John
> ---
> 
> The following changes since commit fcc18e83e1f6fd9fa6b333735bf0fcd530655511:
>   Malcolm Parsons:
>         uclinux: use PER_LINUX_32BIT in binfmt_flat
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

nothing pulled?


