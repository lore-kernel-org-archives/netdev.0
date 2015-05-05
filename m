From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 4/6] e1000: Replace e1000_free_frag with skb_free_frag
Date: Mon, 4 May 2015 17:28:10 -0700
Message-ID: <CAL3LdT58zGo8tDSassf5EGFhL48wpQOuiA+9sX4d53fCGjpiAQ@mail.gmail.com>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
	<20150504231505.1538.58292.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-mm@kvack.org, netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150504231505.1538.58292.stgit@ahduyck-vm-fedora22>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, May 4, 2015 at 4:15 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c |   19 +++++++------------
>  1 file changed, 7 insertions(+), 12 deletions(-)
>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
