From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Patch: Backport of link state notification to 2.4.20
Date: Tue, 03 Dec 2002 19:45:27 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DED5027.7070807@pobox.com>
References: <3DD2D204.C9B7FA2D@isg.de> <3DED302A.E3DEB585@isg.de> <3DED4FB4.5070700@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3DED4FB4.5070700@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Stefan Rompf wrote:
> 
>> Hi David,
>>
>> attached is the recent backport of link state notification for the
>> stable kernel series. The feature is optional and can be configured away
>> to nothing, and tested on several systems.
>>
> 
> It might be a backport, but I haven't seen a 2.5.x version posted in a 
> while.  If this is going into the stable series, it should already be 
> merged in 2.5.x at the same time, if not first.



...and of course this email arrives immediately in my inbox ;-)

Which leads to the question:  why CONFIG_LINKWATCH in 2.4 but not 2.5?

Let's do the same in both kernels unless there is a good reason not to...
