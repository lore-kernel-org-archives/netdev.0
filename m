From: Kevin Bowling <kevin.bowling@kev009.com>
Subject: Re: netmap, VALE and netmap pipes
Date: Mon, 17 Feb 2014 12:12:36 -0700
Message-ID: <ldtmun$dqj$1@ger.gmane.org>
References: <CA+hQ2+gbs9aBneUaDGAnKVoPHspzc=5o+h+f_K=T+Cy8sRxr+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: freebsd-net@freebsd.org
Return-path: <owner-freebsd-net@freebsd.org>
In-Reply-To: <CA+hQ2+gbs9aBneUaDGAnKVoPHspzc=5o+h+f_K=T+Cy8sRxr+w@mail.gmail.com>
List-Unsubscribe: <http://lists.freebsd.org/mailman/options/freebsd-net>,
 <mailto:freebsd-net-request@freebsd.org?subject=unsubscribe>
List-Archive: <http://lists.freebsd.org/pipermail/freebsd-net/>
List-Post: <mailto:freebsd-net@freebsd.org>
List-Help: <mailto:freebsd-net-request@freebsd.org?subject=help>
List-Subscribe: <http://lists.freebsd.org/mailman/listinfo/freebsd-net>,
 <mailto:freebsd-net-request@freebsd.org?subject=subscribe>
Errors-To: owner-freebsd-net@freebsd.org
Sender: owner-freebsd-net@freebsd.org
List-Id: netdev.vger.kernel.org

On 2/17/2014 3:11 AM, Luigi Rizzo wrote:
> Hi,
> we have recently made a few extensions to netmap/VALE and put various
> pieces of code on public repositories, so i thought i'd share the
> pointers. All the code below runs with equal features and performance
> on FreeBSD and Linux, and we are trying to upstream it in the relevant
> projects if possible (as an example, QEMU recently added a netmap backend),
> at which point some of these clone repositories will become unnecessary.

Just a thought, maybe this is a good time for The FreeBSD Foundation to 
reach out to The Linux Foundation for lobbying netmap into their main 
line kernel.  It would be nice if netmap becomes the de facto UNIX 
standard for this type of programming (it is vendor neutral and broadly 
applicable vs other solutions), and avoid not-invented-here APIs like 
non-blocking I/O went through with all the UNIX flavors.

Regards,
Kevin Bowling

_______________________________________________
freebsd-net@freebsd.org mailing list
http://lists.freebsd.org/mailman/listinfo/freebsd-net
To unsubscribe, send any mail to "freebsd-net-unsubscribe@freebsd.org"
