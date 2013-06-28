From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v4 1/2] lib: vsprintf: add IPv4/v6 generic
 %p[Ii]S[pfs] format specifier
Date: Fri, 28 Jun 2013 15:08:43 -0700
Message-ID: <1372457323.29380.23.camel@joe-AO722>
References: <1372441780-9844-1-git-send-email-dborkman@redhat.com>
	 <1372441780-9844-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372441780-9844-2-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-28 at 19:49 +0200, Daniel Borkmann wrote:
> In order to avoid making code that deals with printing both, IPv4 and
> IPv6 addresses, unnecessary complicated as for example ...

Looks good to me.
Thanks Daniel for keeping at it.
