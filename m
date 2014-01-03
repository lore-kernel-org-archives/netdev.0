From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: mmotm 2014-01-02-14-35 uploaded (brocade/bna)
Date: Fri, 03 Jan 2014 10:26:01 -0800
Message-ID: <52C700B9.8040504@infradead.org>
References: <20140102223649.D8FB931C206@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, Rasesh Mody <rmody@brocade.com>,
	linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140102223649.D8FB931C206@corp2gmr1-1.hot.corp.google.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/02/14 14:36, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2014-01-02-14-35 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 

on i386:

as reported for linux-next of Dec.20, 2013
when CONFIG_NEED_DMA_MAP_STATE is not enabled:

drivers/net/ethernet/brocade/bna/bnad.c: In function 'bnad_start_xmit':
drivers/net/ethernet/brocade/bna/bnad.c:3074:26: error: 'struct bnad_tx_vector' has no member named 'dma_len'



-- 
~Randy
