From: "David S. Miller" <davem@redhat.com>
Subject: Re: r8169 and tg3
Date: Tue, 18 Nov 2003 03:01:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118030131.4bf8420a.davem@redhat.com>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com>
	<3FB9A277.70309@pobox.com>
	<20031118100001.GA23615@wsx.ksp.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, brad_mssw@gentoo.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Oravec <jan.oravec@6com.sk>
In-Reply-To: <20031118100001.GA23615@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 18 Nov 2003 11:00:01 +0100
Jan Oravec <jan.oravec@6com.sk> wrote:

> The same problem appears with bcm5700 driver (except 10 ints/sec so the only
> way to make it partially work is to make traffic on eth0).

This smells of interrupt routing issues on this platform.
