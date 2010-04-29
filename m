From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv7] add mergeable buffers support to vhost_net
Date: Thu, 29 Apr 2010 17:12:08 +0300
Message-ID: <20100429141208.GA26418@redhat.com>
References: <1272488232.11307.4.camel@w-dls.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaohui.xin@intel.com, kvm@vger.kernel.org,
        virtualization@lists.osdl.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1272488232.11307.4.camel@w-dls.beaverton.ibm.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 28, 2010 at 01:57:12PM -0700, David L Stevens wrote:
> This patch adds mergeable receive buffer support to vhost_net.
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

You can find the latest version on the following net-next based tree:
git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost

-- 
MST
