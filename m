From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [APPLETALK]: Use '%Z' for size_t.
Date: Thu, 19 Feb 2004 15:27:17 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1077204436.18703.412.camel@hades.cambridge.redhat.com>
References: <200402190209.i1J29KF2020707@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <200402190209.i1J29KF2020707@hera.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-02-18 at 21:11 +0000, Linux Kernel Mailing List wrote:
> ChangeSet 1.1561.2.2, 2004/02/18 13:11:42-08:00, davem@nuts.davemloft.net
> 
> 	[APPLETALK]: Use '%Z' for size_t.

%Zd is an ancient GNUism. Please use %zd in new code instead.

-- 
dwmw2
