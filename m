From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 7 Aug 2008 09:54:22 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808070950260.3859@wrl-59.cs.helsinki.fi>
References: <47EA0DAB.7080205@securenet.de> <200807310939.42406.thomas.jarosch@intra2net.com>
 <20080731094436.12ec99ae@tux> <200807311547.57189.thomas.jarosch@intra2net.com>
 <20080806155306.72039010@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1591372491-1218092062=:3859"
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080806155306.72039010@tux>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1591372491-1218092062=:3859
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 6 Aug 2008, Dâniel Fraga wrote:

> On Thu, 31 Jul 2008 15:47:55 +0200
> Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:
> 
> > If your problem is really FRTO related (that what the patch is for),
> > you could try to disable FRTO temporarily:
> 
> 	Hi, the patch helped, but what's the conclusion? Is the problem
> "solved"? Will this patch be merged in the next kernel? This thread
> seems to be forgotten.

I was yesterday preparing the patch description by adding some more 
thoughts to it (as if there weren't enough already) but didn't yet send it 
with new cover (to sort of notify davem).

I give no guarantees about the _next_ kernel but some 2.6.26.y and 2.6.27
is more likely bet.

-- 
 i.
---696208474-1591372491-1218092062=:3859--
