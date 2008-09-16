From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [git patches] net driver fixes
Date: Tue, 16 Sep 2008 07:02:41 -0700
Message-ID: <20080916070241.3e8d5202@infradead.org>
References: <20080916104811.GC7397@cs181140183.pp.htv.fi>
	<20080916114305.GB10965@ff.dom.local>
	<20080916121528.GD7397@cs181140183.pp.htv.fi>
	<20080916135408.GB13388@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, Jarek Poplawski <jarkao2@gmail.com>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Theodore Tso <tytso@mit.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755329AbYIPODG@vger.kernel.org>
In-Reply-To: <20080916135408.GB13388@mit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2008 09:54:08 -0400
Theodore Tso <tytso@mit.edu> wrote:

> If it's a really important bug, and it affects a huge number of users,
> or it's really bad security bug, the reality is that exceptions will
> be made to the rules.  But exceptions need to remain exceptions for
> extraordinary situations, not everyday occurrences.  And of course, if
> the bug does affect a huge number of users, someone should be asking
> the question why it wasn't detected sooner, say before the last merge
> window --- and to ask the question how many users is this bug really
> going to affect anyway?
> 
> At least, that's my take on things,
> 

also note that Linus said "regression or on the kerneloops list";
if it has any kind of backtrace, it'll be there if it's a common
problem that hits many users.


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
