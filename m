From: Dax Kelson <dax@gurulabs.com>
Subject: Re: 2.6.5, IPSec, NAT funnies
Date: Wed, 28 Apr 2004 11:45:47 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1083174347.2803.9.camel@mentor.gurulabs.com>
References: <1083133394.2817.40.camel@mentor.gurulabs.com>
	 <408F5555.3080303@gmc.lt>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Aidas Kasparas <a.kasparas@gmc.lt>
In-Reply-To: <408F5555.3080303@gmc.lt>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-04-28 at 00:55, Aidas Kasparas wrote:
> Kernel bug. IPSec changes ip headers, but fails to say about this to 
> conntrack. More information 
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=215980
> Patch at 
> http://bugs.debian.org/cgi-bin/bugreport.cgi/ipsec_conntrack.diff?bug=215980&msg=3&att=1

A 7 month old kernel bug with a patch. Is there any reason why this
hasn't been rolled into the Linus tree yet? Is the something
objectionable with the patch?

Dax Kelson
Guru Labs
