From: Stefan Schmidt <s.schmidt@mcbone.net>
Subject: Re: Fw: 2.6.11-mm2 weird ethernet RTTs
Date: Fri, 18 Mar 2005 10:11:40 +0100
Message-ID: <20050318091140.GE30259@giscard.mcbone.net>
References: <20050317115254.4f8e462a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Schmidt <s.schmidt@mcbone.net>, netdev@oss.sgi.com
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050317115254.4f8e462a.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 17, 2005 at 11:52:54AM -0800, Andrew Morton wrote:
> Thanks, Stefan.
> 
> I'm not aware of any changes which would cause this.  Generally -mm's
> networking is the same as Linus's.  Could you test Linus's latest tree?
> (-rc1 should be out very soon, so that would be appropriate)
2.6.10-mm1 was the kernel i ran before 2.6.11-mm2 on this machine which
did not show this behaviour. I will try the latest vanilla as soon as
i'm in office. Perhaps this problem is e1000-driver inflicted, i am
using it as a module - will try latest vanilla with the same setup.

	Stefan
-- 
- The truth is usually just an excuse for a lack of imagination.
Garak, "Improbable Cause", ST-DS9
