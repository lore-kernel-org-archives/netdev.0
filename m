From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v3 1/2] xen-netback: Rename map ops
Date: Thu, 3 Apr 2014 10:06:54 +0100
Message-ID: <1396516014.4211.38.camel@kazak.uk.xensource.com>
References: <1396458298-30041-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jonathan.davies@citrix.com, wei.liu2@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paul.durrant@citrix.com,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1396458298-30041-1-git-send-email-zoltan.kiss@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-04-02 at 18:04 +0100, Zoltan Kiss wrote:
> Rename identifiers to state explicitly that they refer to map ops.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> ---
> v3:
> - rename xenvif_tx_create_gop to xenvif_tx_create_map_op

You can retain my ack from v2.
