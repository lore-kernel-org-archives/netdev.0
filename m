From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Prism54 in 2.6.4-bk2
Date: Tue, 16 Mar 2004 01:14:35 -0500
Sender: prism54-devel-admin@prism54.org
Message-ID: <40569B4B.2020402@pobox.com>
References: <5.1.0.14.2.20040313180709.00ab4250@pop.t-online.de> <1079199572.7111.0.camel@lapy.tuxslare.org> <20040313203058.GY32439@ruslug.rutgers.edu> <20040313221529.GC32439@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux kernel mailing list <linux-kernel@vger.kernel.org>,
	prism54-devel@prism54.org, netdev@oss.sgi.com, jgarzik@redhat.com
Return-path: <prism54-devel-admin@prism54.org>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
In-Reply-To: <20040313221529.GC32439@ruslug.rutgers.edu>
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> Regarding WDS on prism54: on the netdev list we discussed this
> but no one got back to me as to whether we should really just nuke this
> code. Prism54 driver source *does* include WDS support because hey, the
> firmware does. Why wouldn't it go in the driver? We haven't given WDS
> much though anyway since it's also been low priority on our TODO list.

The WDS code was dead code as merged.

If you actually use it, I don't mind adding it :)

	Jeff
