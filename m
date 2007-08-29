From: "Pete Monroe" <pizzlemonrizzle@gmail.com>
Subject: Re: Crash report 2.6.22.5
Date: Tue, 28 Aug 2007 17:06:58 -0700
Message-ID: <24c800fb0708281706n6d92d9d9w7c8defc4a884296b@mail.gmail.com>
References: <24c800fb0708281140r2c46e364i77e041b6c746b60d@mail.gmail.com>
	<6bffcb0e0708281651g29729d6au6b40c0f9af5beed2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org
To: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
In-Reply-To: <6bffcb0e0708281651g29729d6au6b40c0f9af5beed2@mail.gmail.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On 8/28/07, Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:
> Hi Pete,
>
> On 28/08/07, Pete Monroe <pizzlemonrizzle@gmail.com> wrote:
> > Hi,
> >
> > Sorry there's not more to go on here.
> >
> > A 32-bit firewall running the kernel LVS virtual server to fan out to
> > a dozen webservers ran fine for a year using  2.6.17.13, but won't
> > last more than four hours or so with 2.6.22.5.  Another server,
> > different hardware and vendor but same purpose, also crashed with
> > 2.6.22.5 after a few hours.  It had previously run 2.6.20.11.  Nothing
> > on the screen, nothing in the logs.
> >
> > I'm attaching zipped dmesg (both kernel versions),
>
> Could you capture the bug with serial/netconsole etc.?

The servers are remote, production servers and it's a PITA when they
crash.  But I'll see what I can do.  Thanks for the pointer.

--
Pete

>
> "Collecting kernel messages"
> http://www.stardust.webpages.pl/files/handbook/handbook-en-0.3-rc1.pdf
> for more info.
