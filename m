From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] Fix e1000e with Intel 82572EI that has no hardware
 timestamp support
Date: Wed, 6 Aug 2014 21:54:33 +0200
Message-ID: <20140806195433.GD6611@netboy>
References: <bbcbf584e3624059bf7a0d2186fec6b4@FE-MBX1012.de.bosch.com>
 <20140806191744.GB6611@netboy>
 <CAPDOMVjYkfM49E9DM0=SDDRncLQbXxR8NQE9SrsW++YycMGU5w@mail.gmail.com>
 <20140806193211.GC6611@netboy>
 <CAPDOMViFCifeUoOgExuG7Q6_ObGj20g59siyMxWeKN=Zr2Kbdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nick Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPDOMViFCifeUoOgExuG7Q6_ObGj20g59siyMxWeKN=Zr2Kbdg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 06, 2014 at 03:38:18PM -0400, Nick Krause wrote:
> I checked them and this patch seems fine to me.

No, it isn't fine. It ignores Alexander's comments.  Mathias, can you
please fix it?

Thanks,
Richard
