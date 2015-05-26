From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3] net/unix: sk_socket can disappear when state is unlocked
Date: Tue, 26 May 2015 23:24:59 +0200
Message-ID: <1432675499.2339251.278766569.277AF8B9@webmail.messagingengine.com>
References: <1432653777-13799-1-git-send-email-salyzyn@android.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	Christoph Hellwig <hch@lst.de>, netdev@vger.kernel.org
To: Mark Salyzyn <salyzyn@android.com>, hannes@redhat.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432653777-13799-1-git-send-email-salyzyn@android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, May 26, 2015, at 17:22, Mark Salyzyn wrote:
> got a rare NULL pointer dereference in clear_bit
> 
> Signed-off-by: Mark Salyzyn <salyzyn@android.com>

IMHO, this is the right approach, I didn't came up with something
easier, thanks!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
