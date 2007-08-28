From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: Crash report 2.6.22.5
Date: Wed, 29 Aug 2007 01:51:09 +0200
Message-ID: <6bffcb0e0708281651g29729d6au6b40c0f9af5beed2@mail.gmail.com>
References: <24c800fb0708281140r2c46e364i77e041b6c746b60d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org
To: "Pete Monroe" <pizzlemonrizzle@gmail.com>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
In-Reply-To: <24c800fb0708281140r2c46e364i77e041b6c746b60d@mail.gmail.com>
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

Hi Pete,

On 28/08/07, Pete Monroe <pizzlemonrizzle@gmail.com> wrote:
> Hi,
>
> Sorry there's not more to go on here.
>
> A 32-bit firewall running the kernel LVS virtual server to fan out to
> a dozen webservers ran fine for a year using  2.6.17.13, but won't
> last more than four hours or so with 2.6.22.5.  Another server,
> different hardware and vendor but same purpose, also crashed with
> 2.6.22.5 after a few hours.  It had previously run 2.6.20.11.  Nothing
> on the screen, nothing in the logs.
>
> I'm attaching zipped dmesg (both kernel versions),

Could you capture the bug with serial/netconsole etc.?

"Collecting kernel messages"
http://www.stardust.webpages.pl/files/handbook/handbook-en-0.3-rc1.pdf
for more info.

> .config and lspci
> -v output for one of the machines, a Dell Intel dual-Xeon box.  The
> other machine is a dual Athlon box.  Both use SCSI drives (the
> attached Dell uses MPT Fusion, the other one Adaptec.)  Intel ethernet
> on both.
>
> I did enable the Slub allocator in 2.6.22.5, figuring that if it is
> going to be the default in 2.6.23 that it's probably solid in .22.5.
>
> PLMK if any more info would be useful.
>
> Thanks,
> Pete
>
>

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/
