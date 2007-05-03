From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] [AFS]: Fix memory leak in SRXAFSCB_GetCapabilities
Date: Thu, 03 May 2007 03:27:49 -0700 (PDT)
Message-ID: <20070503.032749.63487512.davem@davemloft.net>
References: <20070503095315.26912.24270.stgit@warthog.cambridge.redhat.com>
	<20070503095320.26912.67210.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
To: dhowells@redhat.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161806AbXECK1u@vger.kernel.org>
In-Reply-To: <20070503095320.26912.67210.stgit@warthog.cambridge.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 03 May 2007 10:53:20 +0100

> The interface array is not freed on exit.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks.
