From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [RFC PATCH] softmac: (v2) send WEXT assoc/disassoc events to
 userspace
Date: Thu, 09 Mar 2006 14:36:08 -0600
Message-ID: <441091B8.4010103@lwfinger.net>
References: <1141928917.26954.7.camel@localhost.localdomain> <1141935893.28038.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
   softmac-dev-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, Denis Vlasenko <vda-BN/BzeNzsW2SlH3FCl+8hg@public.gmane.org>,
   David Woodhouse <dwmw2-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <1141935893.28038.2.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> Completely untested, not entirely sure it compiles.  For whatever
> reason, softmac is sending custom events to userspace already, but it
> should _really_ be sending the right WEXT events instead.  Comments?  If
> this looks good, please apply it.
> 
> Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> 

V2 compiles cleanly. It still doesn't authenticate with my WRT54G V5, but that must be another problem.

Larry
