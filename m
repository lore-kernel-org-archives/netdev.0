From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv5] virtio-spec: virtio network device RFS support
Date: Fri, 07 Dec 2012 13:44:30 +1030
Message-ID: <87ehj2ft9l.fsf@rustcorp.com.au>
References: <20121203105843.GA26194@redhat.com>
	<1354739966.2655.25.camel@bwh-desktop.uk.solarflarecom.com>
	<20121206081320.GD10837@redhat.com>
	<1354824194.2828.6.camel@bwh-desktop.uk.solarflarecom.com>
	<20121206202921.GB4340@redhat.com>
	<1354827239.2828.36.camel@bwh-desktop.uk.solarflarecom.com>
	<20121206210132.GB6576@redhat.com>
	<1354831403.2828.63.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Ben Hutchings <bhutchings@solarflare.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1354831403.2828.63.camel@bwh-desktop.uk.solarflarecom.com>
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

Ben Hutchings <bhutchings@solarflare.com> writes:
>  If you want a name for the whole set of
> features involved, I don't see any better name than 'multiqueue'/'MQ'.

OK, let's go back to multiqueue then, and perhaps refer to the current
receive steering as 'automatic'.

Cheers,
Rusty.
