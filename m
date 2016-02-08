From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 5/6] net: thunderx: bgx: Add log message when setting mac
 address
Date: Mon, 8 Feb 2016 16:51:22 +0300
Message-ID: <56B89D5A.8070503@cogentembedded.com>
References: <1454933272-45005-1-git-send-email-sunil.kovvuri@gmail.com>
 <1454933272-45005-6-git-send-email-sunil.kovvuri@gmail.com>
 <56B8987D.7000901@cogentembedded.com> <87vb5z1fd6.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sunil.kovvuri@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com,
	Robert Richter <rrichter@cavium.com>
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87vb5z1fd6.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/08/2016 04:49 PM, Bj=C3=B8rn Mork wrote:

>>     dev_er(), maybe?
>
> I like that!
>
> It's often hard to know whether to print something or be quiet.
> pr_er(), dev_er(), netdev_er() etc would be the perfect solution to t=
hat
> problem.

    :-D
    Sorry for the typo...

> Bj=C3=B8rn

MBR, Sergei
