From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 18:52:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EEE4A1A.6010904@pobox.com>
References: <3EEE28DE.6040808@us.ibm.com> <20030616.133841.35533284.davem@redhat.com> <3EEE2F9F.60706@us.ibm.com> <3EEE492E.9080308@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Janice M Girouard <janiceg@us.ibm.com>,
   "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
   Daniel Stekloff <stekloff@us.ibm.com>,
   Janice Girouard <girouard@us.ibm.com>, Larry Kessler <lkessler@us.ibm.com>,
   kenistonj@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
In-Reply-To: <3EEE492E.9080308@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> 3) _Somebody_ needs to do some "ground pounding", and figure out what 
> info sysadmins and users want to see.  Event logging in general, so far, 
> seems to me more like a management checklist item than a real user 
> need... but I am quite willing to be proved wrong.  Until we get 
> feedback along these lines, I tend to resist changes like this in 
> general.  My initial read of your attached patch was that it was a long 
> of source churn, and I couldn't fathom what any user would gain from it 

make that "a lot of"


> There are a whole bunch of netif_msg_xxx and corresponding NETIF_MSG_xxx 
> bits.  I don't see much need to change that I think getting the logging 
> API right for those would be an important first step.
> 
>     Jeff

arg :)  I should fire my editor.

	Jeff
