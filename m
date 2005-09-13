From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 25/29] ieee80211 use endian-aware types
Date: Tue, 13 Sep 2005 19:48:01 -0400
Message-ID: <200509131948.02083.flamingice@sourmilk.net>
References: <43276290.2010809@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.intel.com>,
        ieee80211-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <43276290.2010809@linux.intel.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 13 September 2005 19:36, James Ketrenos wrote:
> ieee80211: use endian-aware types
>
> From: Michael Wu <flamingice@sourmilk.net>
>
> This patch:
> - fixes misc. whitespace/comments
> - replaces u16 with __le16/__be16 where appropriate
>
> Signed-off-by: Michael Wu <flamingice@sourmilk.net>
> Signed-off-by: Jiri Benc <jbenc@suse.cz>
>
> Signed-off-by: James Ketrenos <jketreno@linux.intel.com>
>
The original patch already went in, and this patch looks nothing like the one 
I sent in.

-Michael Wu
