From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH PKT_SCHED 17/17]: Disable broken override bits in pedit
 action
Date: Thu, 30 Dec 2004 14:25:08 +0100
Message-ID: <41D401B4.7010104@trash.net>
References: <41D378FF.3080205@trash.net> <1104412634.1048.106.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1104412634.1048.106.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

> This way if they are of the same size then things should work as is
> and my testcases dont break. Now if you feel more gracious, go ahead and
> fix them ;->

Yes, this patch was silly, I should have just fixed it.
I'll revert the patch and fix it.

Regards
Patrick
