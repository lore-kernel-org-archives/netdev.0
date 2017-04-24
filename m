From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Networking security fixes
Date: Mon, 24 Apr 2017 20:47:29 +0100
Message-ID: <1493063249.10415.78.camel@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stable <stable@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please queue up these fixes for 4.10.y:

8605330aac5a tcp: fix SCM_TIMESTAMPING_OPT_STATS for normal skbs
4ef1b2869447 tcp: mark skbs with SCM_TIMESTAMPING_OPT_STATS

If I understand correctly, you are no longer sending Greg fixes for
4.4.y or older stable branches, so I'll send stable requests for those
older versions directly.

Please can you also send the pending fixes to Greg soon, as the
AF_PACKET issue is quite serious?

Ben.

-- 
Ben Hutchings
Software Developer, Codethink Ltd.
