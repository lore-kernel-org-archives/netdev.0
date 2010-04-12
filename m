From: stephen mulcahy <smulcahy@gmail.com>
Subject: Bug#572201: forcedeth driver hangs under heavy load
Date: Mon, 12 Apr 2010 13:39:34 +0100
Message-ID: <4BC31486.1090603@gmail.com>
References: <4B9E6C60.7030300@atlanticlinux.ie>	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>	 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie> <1270942606.6179.64.camel@localhost> <4BC2EF88.3060203@atlanticlinux.ie>
Reply-To: stephen mulcahy <smulcahy@gmail.com>, 572201@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>,
 Eric Dumazet <eric.dumazet@gmail.com>,
 Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: netdev <netdev@vger.kernel.org>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.572201.B572201.127107598928692@bugs.debian.org>
In-Reply-To: <4BC2EF88.3060203@atlanticlinux.ie>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

stephen mulcahy wrote:
> It doesn't - further testing over the weekend saw 6 of 45 machines drop 
> off the network with this problem. Nothing in dmesg or system logs. 
> Happy to run more tests if someone can advise on what should be run.

I also just tried using the 2.6.30-2-amd64 (Debian) forcedeth kernel 
module while running the 2.6.32-3-amd64 (Debian) kernel and experienced 
the same symptoms.

Not sure if thats any help.

-stephen
