From: Jamie Lenehan <lenehan@twibble.org>
Subject: Re: 2.5.69 IPv6 (modular) crash on boot
Date: Thu, 8 May 2003 21:48:36 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030508114836.GA1395@twibble.org>
References: <20030506232037.GA5576@twibble.org> <20030506.201618.39175334.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20030506.201618.39175334.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 06, 2003 at 08:16:18PM -0700, David S. Miller wrote:
[...]
>    IPv6 worked fine in 2.5.68, but I get a crash in 2.5.69 on boot. I
>    haven't seen anyone else mention this though. This is a RedHat 8
>    systems with the new modutils added and pretty much everything built
>    modular:
>    
> Yes, we know it's broken and we're thinking about how

Right. I saw all the modules related stuff but no mention of it
actually being broken as is ;) Built in works fine (and I don't see
any reaon not to build it in now that I think about it).

Thanks.

-- 
 Jamie Lenehan              Work Phone: +61 3 9843 8817
 lenehan@twibble.org        Work Email: jamie.lenehan@activcard.com.au
