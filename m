From: "Jason Lunz" <lunz@reflexsecurity.com>
Subject: Re: e1000 typo?
Date: Wed, 30 Jul 2003 14:29:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730182906.GA14121@reflexsecurity.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102229242@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
Content-Disposition: inline
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102229242@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 30, 2003 at 11:24AM -0700, Feldman, Scott wrote:
> It's intentional because && stops evaluating if left op is false which
> means we would leave Tx cleanup work when there was no Rx work.  

ah. subtle yet obvious. :P

-- 
Jason Lunz			Reflex Security
lunz@reflexsecurity.com		http://www.reflexsecurity.com/
