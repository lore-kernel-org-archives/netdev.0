From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC 3/3] virtio_net: limit xmit polling
Date: Thu, 2 Jun 2011 18:44:31 +0300
Message-ID: <20110602154431.GB11300@redhat.com>
References: <cover.1306921434.git.mst@redhat.com>
	<1ec8eec325839ecf2eac9930a230361e7956047c.1306921434.git.mst@redhat.com>
	<87pqmwj3am.fsf@rustcorp.com.au> <20110602133425.GJ7141@redhat.com>
	<OF990F08C5.2ECE35B1-ON652578A3.004DC0FA-652578A3.004E3FE4@in.ibm.com>
	<20110602144346.GA7995@redhat.com>
	<OFFF109303.D838CAE2-ON652578A3.0053357D-652578A3.00549366@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: Krishna Kumar2 <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <OFFF109303.D838CAE2-ON652578A3.0053357D-652578A3.00549366-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 02, 2011 at 08:56:42PM +0530, Krishna Kumar2 wrote:
> Return value in free_old_xmit() was wrong.

Could you check my latest RFC pls?

-- 
MST
