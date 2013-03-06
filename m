From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [PATCH] CAIF: fix indentation for function arguments
Date: Wed, 6 Mar 2013 23:36:32 +0100
Message-ID: <CAJK669ZrEEWX293W+C88xEw4e133yuwz+VJ5cbrsEKXECDQ-8Q@mail.gmail.com>
References: <1362606521-16848-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org,
	Erwan YVIN <Erwan.Yvin@stericsson.com>
To: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362606521-16848-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 6, 2013 at 10:48 PM, Silviu-Mihai Popescu
<silviupopescu1990@gmail.com> wrote:
> This lines up function arguments on second and subsequent lines at th=
e
> first column after the openning parenthesis of the first line.
>
> Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>

There is quite a bit of churn for stuff not even noticed by checkpatch =
--strict,
but it does improve the style...

Acked-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
