From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [patch 1/1] delete unused file
Date: Mon, 27 Dec 2004 05:59:55 +0100
Message-ID: <20041227045955.GA711@linux-mips.org>
References: <20041226151017.C042C1ECC0@trashy.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: domen@coderock.org
Content-Disposition: inline
In-Reply-To: <20041226151017.C042C1ECC0@trashy.coderock.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Dec 26, 2004 at 04:10:32PM +0100, domen@coderock.org wrote:

> Remove nowhere referenced file. (egrep "filename\." didn't find anything)
> 
> Signed-off-by: Domen Puncer <domen@coderock.org>

Great idea to send patches to delete everything that seems unused.  NOT.

Jeff, seems the gt96100 and gt64240 drivers got mixed up, will send a patch
to fix this.

  Ralf
