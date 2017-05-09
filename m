From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] DECnet: Use container_of() for embedded struct
Date: Tue, 09 May 2017 09:40:00 -0400 (EDT)
Message-ID: <20170509.094000.1855173097217010339.davem@davemloft.net>
References: <20170508223144.GA53216@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170508223144.GA53216@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Mon, 8 May 2017 15:31:44 -0700

> Instead of a direct cross-type cast, use conatiner_of() to locate
> the embedded structure, even in the face of future struct layout
> randomization.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
