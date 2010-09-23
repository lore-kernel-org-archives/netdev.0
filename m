From: Alan Ott <alan@signal11.us>
Subject: Re: [PATCH v4 2/2] Bluetooth: hidp: Add support for hidraw  HIDIOCGFEATURE  and HIDIOCSFEATURE
Date: Thu, 23 Sep 2010 10:16:43 -0400
Message-ID: <89BCFDE1-0D39-4248-84B2-E02C1480E067@signal11.us>
References: <1281442367.12579.206.camel@localhost.localdomain> <1281990059-3562-3-git-send-email-alan@signal11.us> <20100923115108.GC2379@null>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jkosina@suse.cz>,
	Stefan Achatz <erazor_de@users.sourceforge.net>,
	Antonio Ospite <ospite@studenti.unina.it>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Tejun Heo <tj@kernel.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stephane Chatty <chatty@enac.fr>,
	Michael Poole <mdpoole@troilus.org>,
	"David S. Miller" <davem@davemloft.net>,
	Bastien Nocera <hadess@hadess.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-input@vger.kernel.org" <linux-input@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ville Tervo <ville.tervo@nokia.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <20100923115108.GC2379@null>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sep 23, 2010, at 7:51 AM, Ville Tervo wrote:

> Hi Alan,
>
> One comment.
>
> How about a variable called ret and using that to return len or  
> errno? It
> would eliminate code dublication.
>

Hi Ville,

Where specifically? In which function? I've gone through it a couple  
of times and failed to find return statements which are superfluous.  
Maybe I'm missing something fundamental?

Alan.


