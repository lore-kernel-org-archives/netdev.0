From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Re: [PATCH 0/14] prism54: bring up to sync with
 prism54.org cvs rep
Date: Thu, 27 May 2004 15:56:11 -0400
Sender: prism54-devel-admin@prism54.org
Message-ID: <40B647DB.4090109@pobox.com>
References: <20040524083003.GA3330@ruslug.rutgers.edu> <20040524085727.GR3330@ruslug.rutgers.edu> <40B62F29.6090101@pobox.com> <20040527192733.GB14186@logos.cnet> <40B6424D.7030203@pobox.com> <20040527194513.GV3330@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>,
	Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-admin@prism54.org>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
In-Reply-To: <20040527194513.GV3330@ruslug.rutgers.edu>
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
> Great. I'll fix all those patches up again for you and Marcelo. For future
> development I've asked other prism54 developers to first send patches to

For what it's worth, you may send a "one big patch" to add the driver to 
2.4, since the individual changes to that point will be in 2.6.x 
BitKeeper changelog.

Once the driver is merged, I do request split-up patches just like 2.6.x.


> netdev for review/approval. Maybe we *should* do away with prism54-devel 
> mailing list and just use netdev as was once suggested by someone...

Up to you :)

	Jeff
