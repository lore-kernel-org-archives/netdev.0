From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 5/6] net: thunderx: bgx: Add log message when setting mac address
Date: Mon, 08 Feb 2016 14:49:41 +0100
Message-ID: <87vb5z1fd6.fsf@nemi.mork.no>
References: <1454933272-45005-1-git-send-email-sunil.kovvuri@gmail.com>
	<1454933272-45005-6-git-send-email-sunil.kovvuri@gmail.com>
	<56B8987D.7000901@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sunil.kovvuri@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com,
	Robert Richter <rrichter@cavium.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B8987D.7000901@cogentembedded.com> (Sergei Shtylyov's message
	of "Mon, 8 Feb 2016 16:30:37 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:

>    dev_er(), maybe?

I like that!

It's often hard to know whether to print something or be quiet.
pr_er(), dev_er(), netdev_er() etc would be the perfect solution to tha=
t
problem.


Bj=C3=B8rn
