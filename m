From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Thu, 7 Apr 2016 08:48:15 -0700
Message-ID: <2816CC0C-686E-43CA-8689-027085255703@oracle.com>
References: <1460034425.20949.7.camel@HansenPartnership.com> <20160407161715.52635cac@redhat.com> <20160407143854.GA7685@infradead.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>, lsf@lists.linux-foundation.org,
        linux-mm <linux-mm@kvack.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        lsf-pc@lists.linux-foundation.org,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160407143854.GA7685@infradead.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


> On Apr 7, 2016, at 7:38 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> This is also very interesting for storage targets, which face the same
> issue.  SCST has a mode where it caches some fully constructed SGLs,
> which is probably very similar to what NICs want to do.

+1 for NFS server.


--
Chuck Lever



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
