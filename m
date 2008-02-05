From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Wireless,
	ath5k] 2.6.24-git13 9135f1901ee6449dfe338adf6e40e9c2025b8150
Date: Tue, 05 Feb 2008 09:54:27 +0100
Message-ID: <47A82443.9000601@gmail.com>
References: <6101e8c40802040600q804e40cs97d0031920e58d9d@mail.gmail.com>	
	<47A774AB.5060008@gmail.com>	
	<6101e8c40802041334o20b2b391la5b0a5f557ee67c5@mail.gmail.com>
	<6101e8c40802041340g749b1e03k70fda7fdb21452d7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bruno Randolf <bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Oliver Pinter <oliver.pntr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
In-Reply-To: <6101e8c40802041340g749b1e03k70fda7fdb21452d7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ath5k.org/pipermail/ath5k-devel>
List-Post: <mailto:ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
List-Help: <mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=subscribe>
Sender: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
Errors-To: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/04/2008 10:40 PM, Oliver Pinter wrote:
> On 2/4/08, Oliver Pinter <oliver.pntr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> On 2/4/08, Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> On 02/04/2008 03:00 PM, Oliver Pinter (Pint=E9r Oliv=E9r) wrote:
>>>> [  413.118874] wpa_supplicant[4388]: segfault at 30 ip 080697ca sp
>>>> bfc9cab0 error 4 in wpa_supplicant[8048000+4c000]
>>> Seems like wpa_supplicant is broken. Is this a regression?
>> yes, but with madwifi is all ok

And this... madwifi goes through ported bsd net80211. So which latest git y=
ou =

tried worked for you when this is a regression, please?
