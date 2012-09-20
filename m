From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 6/6] xfrm_user: don't copy esn replay window twice for
 new states
Date: Thu, 20 Sep 2012 09:27:32 +0200
Message-ID: <20120920072732.GC4221@secunet.com>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
 <1348090423-32665-7-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mathias Krause <minipli@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1348090423-32665-7-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2012 at 11:33:43PM +0200, Mathias Krause wrote:
> The ESN replay window was already fully initialized in
> xfrm_alloc_replay_state_esn(). No need to copy it again.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
