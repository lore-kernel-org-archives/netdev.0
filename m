From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: pppoe handles MOD_DEC_USE_COUNT incorrectly
Date: Sun, 11 May 2003 22:57:12 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030512015712.GE8880@conectiva.com.br>
References: <20030511202728.GA9018@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Hering <olh@suse.de>
Content-Disposition: inline
In-Reply-To: <20030511202728.GA9018@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Sun, May 11, 2003 at 10:27:28PM +0200, Olaf Hering escreveu:
> Hi,
> 
> it seems pppoe does increase its usage count with each reconnect, but it
> never releases it when the ppp connection dies.

I'm looking at this right now, thanks for reporting.

- Arnaldo
