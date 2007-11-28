From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 1/3] Remove trailing NULs from network bonding sysfs interface.
Date: Wed, 28 Nov 2007 07:38:43 -0800
Message-ID: <474D8B83.9050609@oracle.com>
References: <871wabkxcd.fsf@szonett.ki.iif.hu>	<20071127194929.757e4ebe.randy.dunlap@oracle.com> <87bq9ekb8m.fsf@szonett.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Wagner Ferenc <wferi@niif.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761204AbXK1PjX@vger.kernel.org>
In-Reply-To: <87bq9ekb8m.fsf@szonett.ki.iif.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wagner Ferenc wrote:
> Randy Dunlap <randy.dunlap@oracle.com> writes:
> 
>> On Wed, 28 Nov 2007 01:49:54 +0100 =?utf-8?q?Ferenc_W=C3=A1gner?= wrote:
>>
>> Patches 1 & 3 use
>>
>> 	if (res) statement;
>>
>> but the preferred form is
>>
>> 	if (res)
>> 		statement;
>>
>> Even if this style was already used in the source file, it should
>> be cleaned up.
> 
> No principal problem.  So that I learn something useful: how should I
> go about this?  I created the patches with git-format-patch, and they
> depend on each other, so I'd rather not git-reset, if possible...
> 
> Can I just create a follow-up patch which fixes this stylistic issue?

That's OK with me.  I can't say how it might be done with git.

Thanks,
-- 
~Randy
