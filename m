From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCH net-next 06/14] xen: Use eth_<foo>_addr instead of memset
Date: Tue, 3 Mar 2015 10:05:27 +0000
Message-ID: <1425377127.24959.56.camel@citrix.com>
References: <cover.1425354527.git.joe@perches.com>
	 <8762529463d8d2290ef0b67e5ed91f4bccb98b37.1425354528.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8762529463d8d2290ef0b67e5ed91f4bccb98b37.1425354528.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-03-02 at 19:54 -0800, Joe Perches wrote:
> Use the built-in function instead of memset.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>
