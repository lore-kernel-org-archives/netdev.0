From: Greg Kurz <gkurz@linux.vnet.ibm.com>
Subject: Re: [PATCH] KVM: Add Kconfig option to signal cross-endian guests
Date: Mon, 13 Jul 2015 11:24:08 +0200
Message-ID: <20150713112408.060164e1@bahia.local>
References: <20150707195012-mutt-send-email-mst@redhat.com>
 <1436428145-29823-1-git-send-email-thuth@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
 Gleb Natapov <gleb@kernel.org>, linux-kernel@vger.kernel.org,
 kvm-ppc@vger.kernel.org, virtualization@lists.linux-foundation.org,
 Marc Zyngier <marc.zyngier@arm.com>, Paul Mackerras <paulus@samba.org>,
 netdev@vger.kernel.org, Cornelia Huck <cornelia.huck@de.ibm.com>,
 Paolo Bonzini <pbonzini@redhat.com>,
 Linus Torvalds <torvalds@linux-foundation.org>, kvmarm@lists.cs.columbia.edu,
 linux-arm-kernel@lists.infradead.org, kraxel@redhat.com
To: Thomas Huth <thuth@redhat.com>
Return-path: <kvmarm-bounces@lists.cs.columbia.edu>
In-Reply-To: <1436428145-29823-1-git-send-email-thuth@redhat.com>
List-Unsubscribe: <https://lists.cs.columbia.edu/mailman/options/kvmarm>,
 <mailto:kvmarm-request@lists.cs.columbia.edu?subject=unsubscribe>
List-Archive: <https://lists.cs.columbia.edu/pipermail/kvmarm>
List-Post: <mailto:kvmarm@lists.cs.columbia.edu>
List-Help: <mailto:kvmarm-request@lists.cs.columbia.edu?subject=help>
List-Subscribe: <https://lists.cs.columbia.edu/mailman/listinfo/kvmarm>,
 <mailto:kvmarm-request@lists.cs.columbia.edu?subject=subscribe>
Errors-To: kvmarm-bounces@lists.cs.columbia.edu
Sender: kvmarm-bounces@lists.cs.columbia.edu
List-Id: netdev.vger.kernel.org

On Thu,  9 Jul 2015 09:49:05 +0200
Thomas Huth <thuth@redhat.com> wrote:

> The option for supporting cross-endianness legacy guests in
> the vhost and tun code should only be available on systems
> that support cross-endian guests.
> 
> Signed-off-by: Thomas Huth <thuth@redhat.com>

Acked-by: Greg Kurz <gkurz@linux.vnet.ibm.com>
