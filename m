From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] via-rhine: references __init code during resume
Date: Fri, 05 Nov 2004 02:57:58 -0500
Message-ID: <418B3286.5050102@pobox.com>
References: <4179543F.1020407@osdl.org> <418390F2.7080901@pobox.com> <418670AC.7010801@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, rl@hellgate.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <418670AC.7010801@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[jgarzik@pretzel net-drivers-2.6]$ dotest < /g/tmp/mbox
bk import -tpatch -CR -yvia-rhine: references __init code during resume 
/tmp/patch21199 .
Patching...
Patch failed.  **** patch log follows ****
Patching file drivers/net/via-rhine.c
1 out of 1 hunk FAILED -- saving rejects to file drivers/net/via-rhine.c.rej
