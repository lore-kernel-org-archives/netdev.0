From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Fri, 18 Nov 2011 09:54:36 +0100
Message-ID: <20111118085436.GC1615@x4.trippels.de>
References: <20111118072519.GA1615@x4.trippels.de>
 <20111118075521.GB1615@x4.trippels.de>
 <1321605837.30341.551.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "Alex,Shi" <alex.shi@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1321605837.30341.551.camel@debian>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 2011.11.18 at 16:43 +0800, Alex,Shi wrote:
> > > 
> > > The dirty flag comes from a bunch of unrelated xfs patches from Christoph, that
> > > I'm testing right now.
> 
> Where is the xfs patchset? I am wondering if it is due to slub code. It
> is also possible xfs set a incorrect page flags. 

http://thread.gmane.org/gmane.comp.file-systems.xfs.general/41810

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
