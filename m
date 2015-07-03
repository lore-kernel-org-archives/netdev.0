From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PULL] virtio/vhost: cross endian support
Date: Fri, 3 Jul 2015 15:26:00 -0700
Message-ID: <CA+55aFx6Rr8xWTKynja6Miuxhscc0QrfCGWgo4ZzbePCdeKjzA@mail.gmail.com>
References: <20150701113150-mutt-send-email-mst@redhat.com>
	<CA+55aFwE+vO2xevQ5jpyC0uJ7gASDwMS4=aDb=78RsJNA-wN1Q@mail.gmail.com>
	<20150702071412-mutt-send-email-mst@redhat.com>
	<20150703095637-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: KVM list <kvm@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	david@gibson.dropbear.id.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20150703095637-mutt-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 3, 2015 at 12:59 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>
> Linus, could you please clarify whether making the
> feature depend on the cross-endian guest support
> would address your comment, and whether you think
> this can be merged as is, and the dependency added
> after -rc1?

I'll take it. I still think dynamic byte order is a fundamental (and
much too common) mistake, but whatever.

                      Linus
