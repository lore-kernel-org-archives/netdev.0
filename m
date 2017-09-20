From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 14/31] vxfs: Define usercopy region in vxfs_inode slab
 cache
Date: Wed, 20 Sep 2017 13:56:42 -0700
Message-ID: <20170920205642.GA20023@infradead.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
 <1505940337-79069-15-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	linux-mm@kvack.org, kernel-hardening@lists.openwall.com
To: Kees Cook <keescook@chromium.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1505940337-79069-15-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hi Kees,

I've only got this single email from you, which on it's own doesn't
compile and seems to be part of a 31 patch series.

So as-is NAK, doesn't work.

Please make sure to always send every patch in a series to every
developer you want to include.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
