From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Thu, 7 Nov 2002 07:57:11 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211070751280.11183-100000@shell.cyberus.ca>
References: <Pine.LNX.4.44.0211061458310.13934-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Greear <greearb@candelatech.com>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
In-Reply-To: <Pine.LNX.4.44.0211061458310.13934-100000@beohost.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 6 Nov 2002, Donald Becker wrote:

> I can see that changing the parameters is a quick, ad hoc solution.
> This list should focus on identifying the problems, rather than just
> patching in work-arounds.
>

Well said.
Tuning the receive ring is still a mystery; what i have noticed is that
depending on the number of NICs on the system, the most optimal value
varies. Typically, extremely large or small values are bad.

cheers,
jamal
