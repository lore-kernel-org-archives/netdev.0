From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Re: [PATCH 1/2] bluetooth: Rename function bt_err to bt_to_errno
Date: Fri, 1 Jul 2011 16:04:04 -0300
Message-ID: <20110701190404.GE23683@joana>
References: <1309370457.2208.48.camel@aeonflux>
 <cover.1309396408.git.joe@perches.com>
 <895bc01e49b93b9498ca05cfa1bd9cf58cf30df8.1309396408.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <895bc01e49b93b9498ca05cfa1bd9cf58cf30df8.1309396408.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Joe Perches <joe@perches.com> [2011-06-29 18:18:29 -0700]:

> Make it easier to use more normal logging styles later.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  include/net/bluetooth/bluetooth.h |    2 +-
>  net/bluetooth/hci_core.c          |    2 +-
>  net/bluetooth/l2cap_core.c        |    4 ++--
>  net/bluetooth/lib.c               |    4 ++--
>  net/bluetooth/sco.c               |    4 ++--
>  5 files changed, 8 insertions(+), 8 deletions(-)

I applied this one as well. Thanks.

	Gustavo
